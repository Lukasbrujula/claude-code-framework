/**
 * no-success-in-catch — a catch block must not return a success shape.
 *
 * Enforces rules/pipeline-boundaries.md: a critical path fails loudly —
 * propagate the error, or return an explicit error flag plus an alerting
 * event. It never returns { success: true } or a 2xx status after a failure.
 *
 * Flags, inside any catch block:
 *   return { success: true, ... }
 *   res.status(200)... / anything.status(<400)
 *
 * Known limit: a function *defined* inside a catch block (a callback) is
 * also treated as "inside the catch". That over-approximation is deliberate;
 * disable per-line with an eslint-disable comment if a case is genuinely fine.
 */
'use strict';

module.exports = {
  meta: {
    type: 'problem',
    docs: {
      description: 'disallow returning success shapes from catch blocks',
    },
    schema: [],
    messages: {
      successInCatch:
        'Catch block produces a success response — propagate the error, or return an explicit error flag plus an alerting event (rules/pipeline-boundaries.md).',
    },
  },

  create(context) {
    let catchDepth = 0;

    const isSuccessTrue = (prop) =>
      prop.type === 'Property' &&
      (prop.key.name === 'success' || prop.key.value === 'success') &&
      prop.value.type === 'Literal' &&
      prop.value.value === true;

    const isOkStatusCall = (node) =>
      node.type === 'CallExpression' &&
      node.callee.type === 'MemberExpression' &&
      node.callee.property &&
      node.callee.property.name === 'status' &&
      node.arguments.length === 1 &&
      node.arguments[0].type === 'Literal' &&
      typeof node.arguments[0].value === 'number' &&
      node.arguments[0].value < 400;

    return {
      CatchClause() {
        catchDepth += 1;
      },
      'CatchClause:exit'() {
        catchDepth -= 1;
      },
      ReturnStatement(node) {
        if (catchDepth === 0 || !node.argument) return;
        if (
          node.argument.type === 'ObjectExpression' &&
          node.argument.properties.some(isSuccessTrue)
        ) {
          context.report({ node, messageId: 'successInCatch' });
        }
      },
      CallExpression(node) {
        if (catchDepth === 0) return;
        if (isOkStatusCall(node)) {
          context.report({ node, messageId: 'successInCatch' });
        }
      },
    };
  },
};
