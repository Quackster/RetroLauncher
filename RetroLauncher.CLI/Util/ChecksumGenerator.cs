using System.Security.Cryptography;

namespace RetroLauncher.Util
{
    public static class ChecksumGenerator
    {
        public static string? GenerateChecksum(string filePath)
        {
            using (var sha256 = SHA256.Create())
            {
                try
                {
                    using (var fileStream = File.OpenRead(filePath))
                    {
                        byte[] checksum = sha256.ComputeHash(fileStream);
                        return BitConverter.ToString(checksum).Replace("-", String.Empty);
                    }
                }
                catch (FileNotFoundException)
                {
                    return null;
                }
            }
        }
    }
}
