Docker file for .Net application runing on containers to query Hive using beeline 


Example call
string connect = $"beeline -u 'jdbc:hive2://...";
            var process = new Process()
            {
                StartInfo = new ProcessStartInfo()
                {
                    FileName = "/bin/bash",
                    Arguments = $"-c \"{connect}\"",
                    RedirectStandardInput = true,
                    RedirectStandardOutput = true,
                    UseShellExecute = false,
                    CreateNoWindow = true,
                }
            };
            process.Start();
            using (StreamWriter sw = process.StandardInput)
            {
                if (sw.BaseStream.CanWrite)
                {
                    sw.WriteLine(query);
                }
            }
            string result = process.StandardOutput.ReadToEnd();
            process.WaitForExit();
            process.Close();

            return result;
