require 'docopt'

args = {}
begin
	args = Docopt::docopt <<END
Outputs polyrhythm tracker notation.

Usage:
	#{__FILE__} --help
	#{__FILE__} <interval> <interval> [--multiplier=<amt>] [--padding=<amt>] [--ticks=<tpl>] [--output=<file>] [--prefix=<prefix>] [-d] [-n]
	#{__FILE__} <interval> <interval> [--multiplier=<amt>] [--padding=<amt>] [--ticks=<tpl>] [--output=<file>] (-R | -O | --renoise-delay) [-c]

Options:
	--multiplier=<amt>  Set lines between interval1 pulses. [default: 4]
	--output=<file>     Output to a file.
	--padding=<amt>     Set padding of output commands.
	--prefix=<prefix>   Set prefix for commands.
	--ticks=<tpl>       Set ticks per line. (defaults to 12, or 6 if -O is set)
	-O                  Output OpenMPT SDx commands. (sets padding to 1)
	-R                  Output Renoise 0Qxx commands.
	--renoise-delay     Use Renoise's delay column (equivalent to 256 TPL).
	-c                  Output clipboard storage format.
	-d                  Output in decimal (hex by default).
	-h, --help          Show this help text.
	-n                  Don't reduce polyrhythm as much as possible.
END
rescue Docopt::Exit => e
	puts e.message
	exit
end

# defaults
args['--multiplier'] = args['--multiplier'] || 4
args['--prefix'] = args['--prefix'] || ''

# convert to ints
%w(--ticks --padding --multiplier).map do |k|
	args[k] = args[k].to_i
end
args['<interval>'].map! &:to_i

# handle some flags
prefix = args['--prefix']
ticks = args['--ticks']
padding = args['--padding']
if args['-O']
	prefix = 'SD'
	ticks = ticks == 0 ? ticks : 6
	padding = 1
	base = 16
end
if args['-R']
	prefix = 'Q'
	padding = 2
	base = 16
end
if args['--renoise-delay']
	prefix = ''
	ticks = 256
	padding = 2
	base = 16
end
ticks = 12 if ticks == 0
base = args['-d'] ? 10 : 16

raise ArgumentError, "<TPL count: #{ticks}> must be greater than 0!" if ticks < 0

m, n = *args['<interval>'].sort.reverse
# reduce interval if necessary
if !args['-n']
	gcd = m.gcd(n)
	m, n = m/gcd, n/gcd
end
length = m * args['--multiplier']
# the only necessary line below
points = (0...n).map {|x| Rational(x*length, n)} .map {|x| [x.floor, (x%1*ticks).floor]}

# calculate "padding"
# really it's just how many digits are allowed
padding = Math.log(ticks, base).ceil if padding == 0
if Math.log(ticks, base).ceil > padding
	raise ArgumentError, "<TPL count: #{args['--ticks']}> must fit within <padding: #{padding}> digits in base #{base}!"
end

# format
out = []
if !args['-c']
	pad = points[-1][0] == 0 ? 1 : Math.log10(points[-1][0]).floor + 1
	fmt = "row %#{pad}d: #{prefix}%0#{padding}#{base == 16 ? 'X' : 'd'}\n"
	points.each do |row, tick|
		out.push sprintf(fmt, row, tick)
	end
elsif args['-R'] || args['--renoise-delay']
	out.push '<?xml version="1.0" encoding="UTF-8"?>'
	out.push '  <PatternClipboard.BlockBuffer doc_version="0">'
	out.push '    <Columns>'
	out.push '      <Column>'
	out.push '        <Column>'
	out.push '          <Lines>'
	word = args['--renoise-delay'] ? 'Note'  : 'Effect'
	tag =  args['--renoise-delay'] ? 'Delay' : 'Value'
	indent = "  "*5
	i = 0
	points.each do |row, tick|
		until i == row
			out.push "#{indent}<Line />"
			i += 1
		end
		i += 1
		out.push %[#{indent}<Line index="#{row}">]
		out.push %[#{indent}  <#{word}Columns>]
		out.push %[#{indent}    <#{word}Column>]
		out.push sprintf("%s      <#{tag}>%02X</#{tag}>", indent, tick)
		out.push %[#{indent}      <Number>0Q</Number>] if args['-R']
		out.push %[#{indent}    </#{word}Column>]
		out.push %[#{indent}  </#{word}Columns>]
		out.push %[#{indent}</Line>]
	end
	out.push '        </Lines>'
	out.push '        <ColumnType>NoteColumn</ColumnType>'
	out.push '        <SubColumnMask>false false false false true false false false</SubColumnMask>'
	out.push '      </Column>'
	out.push '    </Column>'
	out.push '  </Columns>'
	out.push '</PatternClipboard.BlockBuffer>'
elsif args['-O']
	out.push 'ModPlug Tracker MPT'
	i = 0
	indent = ' ' * 8
	fmt = "|#{indent}SD%01X"
	points.each do |row, tick|
		until i == row
			out.push "|#{indent}..."
			i += 1
		end
		i += 1
		out.push sprintf(fmt, tick)
	end
end

if !args['--output']
	puts out
	exit
end

File.open args['--output'], 'w' do |f|
	f.puts out
end
