using System.Text;

namespace RetroLauncher.Util
{
    public class Patcher
    {
        public static string Obfuscate(string tStr)
        {
            string tResult = string.Empty;
            for (int i = 0; i < tStr.Length; i++)
            {
                int tNumber = (int)tStr[i];
                int tNewNumber1 = (tNumber & 15) * 2;
                int tNewNumber2 = (tNumber & 240) / 8;
                int tRandom = new Random().Next(1, 7);
                tNewNumber1 += ((tRandom & 6) * 16) + (tRandom & 1);
                tRandom = new Random().Next(1, 7);
                tNewNumber2 += ((tRandom & 6) * 16) + (tRandom & 1);
                tResult += (char)tNewNumber2 + "" + (char)tNewNumber1;
            }
            return tResult;
        }

        public static string Deobfuscate(string tStr)
        {
            string tResult = string.Empty;
            for (int i = 0; i < tStr.Length; i++)
            {
                if (i >= tStr.Length - 1) break;
                int[] tRawNumbers = { (int)tStr[i + 1], (int)tStr[i] };
                int[] tNumbers = { (tRawNumbers[0] & 30) / 2, (tRawNumbers[1] & 30) * 8 };
                int tNumber = tNumbers[0] | tNumbers[1];
                tResult += (char)tNumber;
                i++;
            }
            return tResult;
        }

        public static int LocateFileOffset(string exeFilePath)
        {
            byte[] projectorBytes = File.ReadAllBytes(exeFilePath);

            int offset = 0;
            bool found = false;

            while (!found)
            {
                found = true;

                for (int i = 0; i < 2000; i++)
                {
                    if (projectorBytes[i + offset] != '|')
                    {
                        found = false;
                    }
                }

                if (found)
                {
                    break;
                }

                offset++;
            }

            return offset;
        }

        public static byte[] BuildProjectorAttributes(int fileOffset, string exeFilePath, string replacementString)
        {
            replacementString = replacementString.Replace("\r", "");
            replacementString = replacementString.Replace("\n\n", "\n");
            replacementString = replacementString.Replace("\n\n", "\n");
            //replacementString = Obfuscate(replacementString);

            string? obfuscated = null;
            int attempts = 0;

            while (obfuscated == null || obfuscated.Contains("|"))
            {
                obfuscated = Obfuscate(replacementString);

                attempts++;
            }


            byte[] replacementBytes = Encoding.Default.GetBytes(obfuscated);// File.ReadAllBytes("obfuscated_bin");
            byte[] projectorBytes = File.ReadAllBytes(exeFilePath);

            for (int i = 0; i < replacementBytes.Length; i++)
            {
                projectorBytes[i + fileOffset] = replacementBytes[i];
            }

            /*
            offset += replacementBytes.Length;

            for (int i = 0; i < 2000 - replacementBytes.Length; i++)
            {
                projectorBytes[i + offset] = (byte)' ';
            }
            */

            return projectorBytes;
        }
    }
}