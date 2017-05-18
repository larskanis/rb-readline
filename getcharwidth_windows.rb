require 'fiddle'
require 'fiddle/import'

module Kernel32
  extend Fiddle::Importer
  dlload 'kernel32'

  typealias 'BOOL', 'int'
  typealias 'SHORT', 'short'
  typealias 'WORD', 'unsigned short'
  typealias 'DWORD', 'unsigned int'
  typealias 'PCONSOLE_SCREEN_BUFFER_INFO', 'CONSOLE_SCREEN_BUFFER_INFO *'
  typealias 'HANDLE', 'void *'

  Struct_CONSOLE_SCREEN_BUFFER_INFO = struct ['SHORT dwSizeX', 'SHORT dwSizeY',
        'SHORT dwCursorPositionX', 'SHORT dwCursorPositionY',
        'WORD wAttributes',
        'SHORT srWindowLeft', 'SHORT srWindowTop', 'SHORT srWindowRight', 'SHORT srWindowBottom',
        'SHORT dwMaximumWindowSizeX', 'SHORT dwMaximumWindowSizeY']

  STD_INPUT_HANDLE = -10
  STD_OUTPUT_HANDLE = -11
  STD_ERROR_HANDLE = -12

  extern 'HANDLE GetStdHandle(DWORD nStdHandle)'
  extern 'HANDLE GetStdHandle(DWORD nStdHandle)'

  extern 'BOOL GetConsoleScreenBufferInfo( HANDLE hConsoleOutput, PCONSOLE_SCREEN_BUFFER_INFO lpConsoleScreenBufferInfo)'
end

def get_cursor_pos
  stdout_handle = Kernel32.GetStdHandle(Kernel32::STD_OUTPUT_HANDLE)
  buffer_info = Kernel32::Struct_CONSOLE_SCREEN_BUFFER_INFO.malloc

  if Kernel32.GetConsoleScreenBufferInfo(stdout_handle, buffer_info) == 0
    raise "GetConsoleScreenBufferInfo failed"
  end
  [buffer_info.dwCursorPositionX, buffer_info.dwCursorPositionY]
end

WCWIDTHS = Array.new(0x10000, 0xff)

[ 0x20...0xD800,
  0xE000...0xFDD0,
  0xFDF0...0xFFFE,
].each do |range|
  range.each do |uc|
    x1,y1 = get_cursor_pos
    print [uc].pack("U".freeze)
    x2,y2 = get_cursor_pos
    WCWIDTHS[uc] = x2-x1

    puts if x2>=80
  end
end
print "\n\n"
puts "Zlib compressed character widths:"
puts

require "zlib"
z = Zlib.deflate(WCWIDTHS.pack("C*"))
puts [z].pack("m")
