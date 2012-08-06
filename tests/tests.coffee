fs = require 'fs'
assert = require 'assert'
{exec} = require 'child_process'
{spawn_with_output} = require 'uiautomation-runner'
PNG_GUTS = require('png-guts').BIN_PATH
async = require 'async'
mkdirp = require 'mkdirp'


SETTINGS = {
  xcode_project: "#{__dirname}/../redact-by-example.xcodeproj"
  xcode_scheme: 'redact-by-example'
  xcode_sdk: 'macosx10.7'
  xcode_configuration: 'Release'
  build_dir: "#{__dirname}/build"
}


main = () ->
  async.series [
    ((c) -> mkdirp SETTINGS.build_dir, c)
    xcodebuild
    run_tests
  ], (e) ->
    throw e if e
    console.log 'OK'


xcodebuild = (c) ->
  spawn_with_output "xcodebuild", [
    '-project',       SETTINGS.xcode_project,
    '-scheme',        SETTINGS.xcode_scheme,
    '-sdk',           SETTINGS.xcode_sdk,
    '-configuration', SETTINGS.xcode_configuration,
    'build',
    ('CONFIGURATION_BUILD_DIR=' + SETTINGS.build_dir)
  ], {noisy:true}, c


run_tests = (c) ->
  bin = "#{SETTINGS.build_dir}/redact-by-example"
  example = "#{__dirname}/redacted.png"
  src = "#{__dirname}/subject.png"
  dest = "#{__dirname}/build/result.png"
  dest_stripped = "#{__dirname}/build/result-stripped.png"
  exec "'#{bin}' #{example} #{src} #{dest} 0 0 255", (e, out, err) ->
    return c e if e
    exec "cat '#{dest}' | '#{PNG_GUTS}' --strip-ancillary > '#{dest_stripped}'", (e, out, err) ->
      return c e if e
      exec "compare -metric RMSE '#{dest_stripped}' '#{__dirname}/result-expected.png' /dev/null", (e, out, err) ->
        return c e if e
        assert.equal err, "0 (0)\n"
        c null


module.exports = {main}
if not module.parent
  main()
