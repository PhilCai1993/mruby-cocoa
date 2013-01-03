#include "cocoa.h"

#include "mruby.h"
#include "mruby/dump.h"
#include "mruby/proc.h"
#include "mruby/compile.h"

const char* cocoa_assert_rb = " \
class MobiRubyTest \n\
  def initialize(label) \n\
    @label = label \n\
    @index = 0 \n\
  end \n\
\
  def run(&block) \n\
    begin \n\
      instance_eval(&block) \n\
    rescue Exception => e \n\
      str = \n\"#{@label} ##{@index}\" \n\
      $asserts.push(['Error: ', str, '', e]) \n\
      $kill_test += 1 \n\
      print('X') \n\
    end \n\
  end \n\
\
  def assert(result, label='') \n\
    @index += 1 \n\
    str = \"#{@label} ##{@index} #{label}\" \n\
    if !result \n\
      $asserts.push(['Fail: ', str, ''])\n \n\
      $ko_test += 1 \n\
      print('F') \n\
    else \n\
      $ok_test += 1 \n\
      print('.') \n\
    end \n\
  end \n\
\
  def assert_equal(a, b) \n\
    assert(a===b, \n\"<#{a.inspect}> expected but was <#{b.inspect}>\") \n\
  end \n\
\
  def assert_not_equal(a, b) \n\
    assert(!(a===b), \n\"<#{a.inspect}> not expected but was <#{b.inspect}>\") \n\
  end \n\
end \n\
\
def mobiruby_test(label, &block) \n\
  MobiRubyTest.new(label).run(&block) \n\
end";


struct BridgeSupportStructTable struct_table[];
struct BridgeSupportConstTable const_table[];
struct BridgeSupportEnumTable enum_table[];

void
mrb_mruby_cocoa_gem_test_init(mrb_state *mrb)
{
    load_cocoa_bridgesupport(mrb, struct_table, const_table, enum_table);  
    mrb_load_string(mrb, cocoa_assert_rb);
    if (mrb->exc) {
        mrb_p(mrb, mrb_obj_value(mrb->exc));
        exit(1);
    }
}
