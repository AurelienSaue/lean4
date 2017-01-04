/*
Copyright (c) 2016 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

Author: Leonardo de Moura
*/
#pragma once
#include "frontends/lean/parser.h"
namespace lean {
expr parse_begin_end_expr(parser & p, pos_info const & pos);
expr parse_curly_begin_end_expr(parser & p, pos_info const & pos);
expr parse_begin_end(parser & p, unsigned, expr const *, pos_info const & pos);
expr parse_by(parser & p, unsigned, expr const *, pos_info const & pos);
expr parse_auto_quote_tactic_block(parser & p, unsigned, expr const *, pos_info const & pos);
bool is_begin_end_block(expr const & e);
bool is_begin_end_element(expr const & e);
void get_begin_end_block_elements(expr const & e, buffer<expr> & elems);
expr update_begin_end_block(expr const & e, buffer<expr> const & elems);
void initialize_tactic_notation();
void finalize_tactic_notation();
}
