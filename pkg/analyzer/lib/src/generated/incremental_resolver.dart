// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/exception/exception.dart';
import 'package:analyzer/src/generated/resolver.dart';

/// The context to resolve an [AstNode] in.
class ResolutionContext {
  CompilationUnitElement enclosingUnit;
  ClassDeclaration enclosingClassDeclaration;
  ClassElement enclosingClass;
  Scope scope;
}

/// Instances of the class [ResolutionContextBuilder] build the context for a
/// given node in an AST structure. At the moment, this class only handles
/// top-level and class-level declarations.
class ResolutionContextBuilder {
  /// The class containing the enclosing [CompilationUnitElement].
  CompilationUnitElement _enclosingUnit;

  /// The class containing the enclosing [ClassDeclaration], or `null` if we are
  /// not in the scope of a class.
  ClassDeclaration _enclosingClassDeclaration;

  /// The class containing the enclosing [ClassElement], or `null` if we are not
  /// in the scope of a class.
  ClassElement _enclosingClass;

  Scope _scopeFor(AstNode node) {
    if (node is CompilationUnit) {
      return _scopeForAstNode(node);
    }
    AstNode parent = node.parent;
    if (parent == null) {
      throw AnalysisException(
          "Cannot create scope: node is not part of a CompilationUnit");
    }
    return _scopeForAstNode(parent);
  }

  /// Return the scope in which the given AST structure should be resolved.
  ///
  /// *Note:* This method needs to be kept in sync with
  /// [IncrementalResolver.canBeResolved].
  ///
  /// [node] - the root of the AST structure to be resolved.
  ///
  /// Throws [AnalysisException] if the AST structure has not been resolved or
  /// is not part of a [CompilationUnit]
  Scope _scopeForAstNode(AstNode node) {
    if (node is CompilationUnit) {
      return _scopeForCompilationUnit(node);
    }
    AstNode parent = node.parent;
    if (parent == null) {
      throw AnalysisException(
          "Cannot create scope: node is not part of a CompilationUnit");
    }
    Scope scope = _scopeForAstNode(parent);
    if (node is ClassDeclaration) {
      _enclosingClassDeclaration = node;
      _enclosingClass = node.declaredElement;
      if (_enclosingClass == null) {
        throw AnalysisException("Cannot build a scope for an unresolved class");
      }
      scope = ClassScope(
          TypeParameterScope(scope, _enclosingClass), _enclosingClass);
    } else if (node is ClassTypeAlias) {
      ClassElement element = node.declaredElement;
      if (element == null) {
        throw AnalysisException(
            "Cannot build a scope for an unresolved class type alias");
      }
      scope = ClassScope(TypeParameterScope(scope, element), element);
    } else if (node is ConstructorDeclaration) {
      ConstructorElement element = node.declaredElement;
      if (element == null) {
        throw AnalysisException(
            "Cannot build a scope for an unresolved constructor");
      }
      FunctionScope functionScope = FunctionScope(scope, element);
      functionScope.defineParameters();
      scope = functionScope;
    } else if (node is FunctionDeclaration) {
      ExecutableElement element = node.declaredElement;
      if (element == null) {
        throw AnalysisException(
            "Cannot build a scope for an unresolved function");
      }
      FunctionScope functionScope = FunctionScope(scope, element);
      functionScope.defineParameters();
      scope = functionScope;
    } else if (node is FunctionTypeAlias) {
      scope = FunctionTypeScope(scope, node.declaredElement);
    } else if (node is MethodDeclaration) {
      ExecutableElement element = node.declaredElement;
      if (element == null) {
        throw AnalysisException(
            "Cannot build a scope for an unresolved method");
      }
      FunctionScope functionScope = FunctionScope(scope, element);
      functionScope.defineParameters();
      scope = functionScope;
    }
    return scope;
  }

  Scope _scopeForCompilationUnit(CompilationUnit node) {
    _enclosingUnit = node.declaredElement;
    if (_enclosingUnit == null) {
      throw AnalysisException(
          "Cannot create scope: compilation unit is not resolved");
    }
    LibraryElement libraryElement = _enclosingUnit.library;
    if (libraryElement == null) {
      throw AnalysisException(
          "Cannot create scope: compilation unit is not part of a library");
    }
    return LibraryScope(libraryElement);
  }

  /// Return the context in which the given AST structure should be resolved.
  ///
  /// [node] - the root of the AST structure to be resolved.
  ///
  /// Throws [AnalysisException] if the AST structure has not been resolved or
  /// is not part of a [CompilationUnit]
  static ResolutionContext contextFor(AstNode node) {
    if (node == null) {
      throw AnalysisException("Cannot create context: node is null");
    }
    // build scope
    ResolutionContextBuilder builder = ResolutionContextBuilder();
    Scope scope = builder._scopeFor(node);
    // prepare context
    ResolutionContext context = ResolutionContext();
    context.scope = scope;
    context.enclosingUnit = builder._enclosingUnit;
    context.enclosingClassDeclaration = builder._enclosingClassDeclaration;
    context.enclosingClass = builder._enclosingClass;
    return context;
  }
}
