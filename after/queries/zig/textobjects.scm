; extends

; ─── Functions ───────────────────────────────────────────────────────────────
(function_declaration) @function.outer
(function_declaration
  body: (block) @function.inner)

; ─── Parameters ──────────────────────────────────────────────────────────────
(parameter) @parameter.inner
(parameters) @parameter.outer

; ─── Structs (treat like classes) ────────────────────────────────────────────
(struct_declaration) @class.outer
(struct_declaration
  (container_field) @class.inner)

; ─── Conditionals ────────────────────────────────────────────────────────────
(if_statement) @conditional.outer
(if_statement
  consequence: (block) @conditional.inner)

; ─── Loops ───────────────────────────────────────────────────────────────────
(for_statement) @loop.outer
(for_statement
  body: (block) @loop.inner)

(while_statement) @loop.outer
(while_statement
  body: (block) @loop.inner)

; ─── Blocks ──────────────────────────────────────────────────────────────────
(block) @block.outer
(block (_) @block.inner)

; ─── Comments ────────────────────────────────────────────────────────────────
(line_comment) @comment.outer
