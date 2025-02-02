#addin nuget:?package=Cake.Git
#tool "nuget:?package=NUnit.ConsoleRunner"

var target = Argument("target", "Default");
var solution = File("./BugsnagUnity.sln");
var configuration = Argument("configuration", "Release");
var project = File("./src/BugsnagUnity/BugsnagUnity.csproj");
var version = "5.2.0";

Task("Restore-NuGet-Packages")
    .Does(() => NuGetRestore(solution));

Task("Build")
  .IsDependentOn("Restore-NuGet-Packages")
  .Does(() => {
    MSBuild(solution, settings =>
      settings
        .SetVerbosity(Verbosity.Minimal)
        .WithProperty("Version", version)
        .SetConfiguration(configuration));
  });

Task("Test")
  .IsDependentOn("Build")
  .Does(() => {
    var assemblies = GetFiles($"./tests/**/bin/{configuration}/**/*.Tests.dll");
    NUnit3(assemblies);
  });

Task("Default")
  .IsDependentOn("Test");

RunTarget(target);
