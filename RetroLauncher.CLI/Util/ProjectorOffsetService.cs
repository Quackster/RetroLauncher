namespace RetroLauncher.Util
{
    public class ProjectorOffsetService
    {
        private Dictionary<string, int> offsets;

        public ProjectorOffsetService()
        {
            offsets = new Dictionary<string, int>();
            LoadOffsetsFromFile();
        }

        private void LoadOffsetsFromFile()
        {
            try
            {
                string filePath = "offsets.ini";
                string[] lines = File.ReadAllLines(filePath);

                foreach (string line in lines)
                {
                    string[] parts = line.Split('=');

                    if (parts.Length == 2)
                    {
                        string checksum = parts[0].Trim();
                        int offset = int.Parse(parts[1].Trim());

                        offsets[checksum] = offset;
                    }
                }
            }
            catch (FileNotFoundException)
            {
                Console.WriteLine("offsets.ini file not found.");
            }
            catch (Exception ex)
            {
                Console.WriteLine("An error occurred while loading offsets: " + ex.Message);
            }
        }

        public int GetOffsetByChecksum(string checksum)
        {
            if (offsets.ContainsKey(checksum))
            {
                return offsets[checksum];
            }

            return -1; // Return -1 if the checksum is not found
        }
    }
}
