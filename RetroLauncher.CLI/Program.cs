using RetroLauncher.Util;

namespace RetroLauncher
{
    internal class Program
    {
        static void Main(string[] args)
        {
            if (args.Length < 1)
            {
                Console.WriteLine("Usage: RetroLauncher <file1> [file2 ...] [--key=value ...]");
                return;
            }

            List<string> files = new List<string>();
            Dictionary<string, string> config = new Dictionary<string, string>();

            // Separate files and --key=value args
            foreach (var arg in args)
            {
                if (arg.StartsWith("--"))
                {
                    var split = arg.Substring(2).Split('=', 2);
                    if (split.Length == 2)
                        config[split[0]] = split[1];
                }
                else
                {
                    files.Add(arg);
                }
            }

            foreach (var file in files)
            {
                if (!File.Exists(file))
                {
                    Console.WriteLine($"File not found: {file}");
                    continue;
                }

                try
                {

                    string offsetsFile = "offsets.ini";

                    string? checksum = ChecksumGenerator.GenerateChecksum(file);
                    int offset = Patcher.LocateFileOffset(file);

                    if (checksum != null)
                    {
                        string lineToAdd = $"{checksum} = {offset}";

                        // Ensure the file exists
                        if (!File.Exists(offsetsFile))
                        {
                            File.WriteAllText(offsetsFile, ""); // Create an empty file if it doesn't exist
                        }

                        // Read all lines and check for existing checksum
                        var lines = File.ReadAllLines(offsetsFile).ToList();
                        bool found = false;

                        for (int i = 0; i < lines.Count; i++)
                        {
                            if (lines[i].StartsWith($"{checksum} ="))
                            {
                                lines[i] = lineToAdd; // Update the line
                                found = true;
                                break;
                            }
                        }

                        if (!found)
                        {
                            lines.Add(lineToAdd); // Append if not found
                        }

                        File.WriteAllLines(offsetsFile, lines); // Write back to file
                    }

                    Patch(file, config);
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error processing {file}: {ex.ToString()}");
                }
            }
        }


        static void Patch(string exeFilePath, Dictionary<string, string> config)
        {
            var scriptText = @"property pMovie, pExternalTexts, pExternalVariables, pGameIp, pGamePort, pMusIp, pMusPort, pSitePath, pSsoPath, pIsSsoLogin, pProjectorSizeWidth, pProjectorSizeHeight

on construct me
  pMovie = ""{projector.movieDCR}""
  pExternalTexts = ""{projector.externalTexts}""
  pExternalVariables = ""{projector.externalVariables}""
  pGameIp = ""{projector.connectionInfoHost}""
  pGamePort = {projector.connectionInfoPort}
  pMusIp = ""{projector.connectionMusHost}""
  pMusPort = {projector.connectionMusPort}
  pSitePath = ""{projector.sitePath}""
  pSsoPath = ""{projector.ssoPath}""
  pIsSsoLogin = {projector.isSsoLogin}
  pProjectorSizeWidth = {projector.pProjectorSizeWidth}
  pProjectorSizeHeight = {projector.pProjectorSizeHeight}
end";

            var projector = new
            {
                ConnectionInfoHost = GetValue(config, "infoHost", "localhost"),
                ConnectionMusHost = GetValue(config, "musHost", "localhost"),
                ConnectionInfoPort = int.Parse(GetValue(config, "infoPort", "12321")),
                ConnectionMusPort = int.Parse(GetValue(config, "musPort", "12322")),
                ExternalVariables = GetValue(config, "varsUrl", "http://localhost/v31/external_vars.txt?"),
                ExternalTexts = GetValue(config, "textsUrl", "http://localhost/v31/external_texts.txt?"),
                MoviePath = GetValue(config, "movieUrl", "http://localhost/v31/habbo.dcr?"),
                SitePath = GetValue(config, "sitePath", "http://localhost"),
                IsSsoEnabled = bool.Parse(GetValue(config, "sso", "false")),
                SsoPath = GetValue(config, "ssoPath", "http://localhost/api/login"),
                Width = GetValue(config, "width", "960"),
                Height = GetValue(config, "height", "540")
            };

            Console.WriteLine("Checksum: " + ChecksumGenerator.GenerateChecksum(exeFilePath));


            // Replace template values in script
            scriptText = scriptText
                .Replace("{projector.connectionInfoHost}", projector.ConnectionInfoHost)
                .Replace("{projector.connectionInfoPort}", projector.ConnectionInfoPort.ToString())
                .Replace("{projector.connectionMusHost}", projector.ConnectionMusHost)
                .Replace("{projector.connectionMusPort}", projector.ConnectionMusPort.ToString())
                .Replace("{projector.movieDCR}", projector.MoviePath)
                .Replace("{projector.externalVariables}", projector.ExternalVariables)
                .Replace("{projector.externalTexts}", projector.ExternalTexts)
                .Replace("{projector.sitePath}", projector.SitePath)
                .Replace("{projector.ssoPath}", projector.SsoPath)
                .Replace("{projector.isSsoLogin}", projector.IsSsoEnabled ? "TRUE" : "FALSE")
                .Replace("{projector.pProjectorSizeWidth}", projector.Width)
                .Replace("{projector.pProjectorSizeHeight}", projector.Height);

            var projectorOffsetService = new ProjectorOffsetService();
            var fileOffset = projectorOffsetService.GetOffsetByChecksum(ChecksumGenerator.GenerateChecksum(exeFilePath));

            var outputScriptPath = $"scriptText_output_{Path.GetFileNameWithoutExtension(exeFilePath)}.txt";
            File.WriteAllText(outputScriptPath, scriptText);

            var patchedFilePath = "new_" + Path.GetFileName(exeFilePath);
            File.WriteAllBytes(patchedFilePath, Patcher.BuildProjectorAttributes(fileOffset, exeFilePath, scriptText));

            Console.WriteLine($"Patched file written to: {patchedFilePath}");
        }

        static string GetValue(Dictionary<string, string> config, string key, string defaultValue)
        {
            return config.TryGetValue(key, out var value) ? value : defaultValue;
        }
    }
}