{Range} = require 'atom'

# wordRegExp is based on atom.workspace.getActiveTextEditor().getLastCursor().wordRegExp()
wordRegExp = /^[	 ]*$|[^\s\/\\\(\)"',\.;<>~#\$%\^&\*\|\+=\[\]\{\}`\-…]+|[\/\\\(\)"',\.;<>~!#\$%\^&\*\|\+=\[\]\{\}`\?\-…]+/g

getSubjectAndMarkerRange = (editor, bufferPosition) ->
  wordAndRange = getWordAndRange(editor, bufferPosition, wordRegExp)
  word = wordAndRange.word
  range = wordAndRange.range

  if (editor.getGrammar().scopeName != 'source.elixir')
    return null

  if (!word.match(/[a-zA-Z_]/) || word.match(/\:$/))
    return null

  line = editor.getTextInRange([[range.start.row, 0], range.end])
  regex = /[\w0-9\._!\?\:\@]+$/
  matches = line.match(regex)
  subject = (matches && matches[0]) || ''

  if (['do', 'fn', 'end', 'false', 'true', 'nil'].indexOf(word) > -1)
    return null

  return {subject: subject, range: range}

getWordAndRange = (editor, position, wordRegExp) ->
  wordAndRange = { word: '', range: new Range(position, position) }
  buffer = editor.getBuffer()
  buffer.scanInRange wordRegExp, buffer.rangeForRow(position.row), (data) ->
    if data.range.containsPoint(position)
      wordAndRange = { word: data.matchText, range: data.range }
      data.stop()
    else if data.range.end.column > position.column
      data.stop()
  return wordAndRange

module.exports = {getSubjectAndMarkerRange}
