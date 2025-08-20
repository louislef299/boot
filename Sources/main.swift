import ArgumentParser

@main
struct Boot: ParsableCommand {
  @Option(help: "Specify the input")
  public var input: String

  public func run() throws {
    print(self.input)
  }
}
