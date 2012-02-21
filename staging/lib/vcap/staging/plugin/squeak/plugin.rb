class SqueakPlugin < StagingPlugin
  include GemfileSupport

  SMALLTALK_HOME = File.expand_path("~/smalltalk")

  def framework
    'squeak'
  end

  def stage_application
    Dir.chdir(destination_directory) do
      create_app_directories
      copy_source_files
      do_staging
      create_startup_script
      create_stop_script
    end
  end

  def do_staging

    Dir.chdir("app") do |dir|
      `cp #{SMALLTALK_HOME}/squeak/Squeak.changes Squeak.changes`
      `cp #{SMALLTALK_HOME}/squeak/Squeak.image Squeak.image`
      `ln -s #{SMALLTALK_HOME}/squeak/Squeak*.sources ./` # Creates a symlink of the same name as the file
      # Set the author to be CloudFoundry, mirror the Transcript to a log file, then evaluate the load file
      staging = <<-EOF
        | file contents |
        Utilities setAuthorInitials: 'CloudFoundry'.

        TranscriptStream compile: 'endEntry
	  "Display all the characters since the last endEntry, and reset the stream"
	  self semaphore critical:[
            self changed: #appendEntry.
            self logEntry.
            self reset.
	  ].'.
        TranscriptStream compile: 'logEntry
          (StandardFileStream fileNamed: ''transcript.log'')
            setToEnd;
            nextPutAll: self contents;
            crlf;
            close.'.

        file := FileStream readOnlyFileNamed: 'squeak.st'.
        contents := file contentsOfEntireFile.
        Compiler evaluate: contents.
        SmalltalkImage current snapshot: true andQuit: true.
      EOF
      File.open("staging.st", "w") {|f| f.write(staging) }
      run = "#{SMALLTALK_HOME}/cog/bin/squeak -vm-display-null -vm-sound-null Squeak.image staging.st"
      puts system(run)
      `chmod 400 Squeak.image`
      main = ""
      File.open("main.st", "w") {|f| f.write( main ) }
    end 
  end

  def start_command
    "#{SMALLTALK_HOME}/cog/bin/squeak -vm-display-null -vm-sound-null " +
      "Squeak.image main.st $VCAP_APP_PORT $@"
  end

  private
  def startup_script
    vars = environment_hash
    # PWD here is after we change to the 'app' directory.
    generate_startup_script(vars) do
      "# squeak startup script"
    end
  end

  def stop_script
    vars = environment_hash
    generate_stop_script(vars)
  end
end

