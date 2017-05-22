module Programs
  @@programs = [] of String

  def self.load
    dir = "./public/programs/"
    Dir.entries(dir).each do |file|
      @@programs << dir + file unless File.directory?(dir + file)
    end
  end

  def self.[](index)
    @@programs[index]
  end

  def self.to_a
    @@programs
  end
end