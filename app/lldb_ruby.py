def __lldb_init_module(debugger, dict):
  debugger.HandleCommand('command script add -f lldb_ruby.rbp rbp')

def rbp(debugger, variable, result, dict):
  frame = debugger.GetSelectedTarget().GetProcess().GetSelectedThread().GetSelectedFrame()
  frame.EvaluateExpression('VALUE $__rbp__ = (VALUE)rb_inspect((VALUE)%s)' % variable)
  print >>result, frame.EvaluateExpression('(char *)rb_string_value_ptr(&$__rbp__)').GetSummary()[1:-1]
  frame.EvaluateExpression('VALUE $__rbp__ = Qnil')
