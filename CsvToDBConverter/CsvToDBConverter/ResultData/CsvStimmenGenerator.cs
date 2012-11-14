using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CsvToDBConverter.RawData;

namespace CsvToDBConverter.ResultData
{
    internal class CsvStimmenGenerator
    {
        private readonly int _ramBulkLoadSize;

        public CsvStimmenGenerator(int ramBulkLoadSize)
        {
            this._ramBulkLoadSize = ramBulkLoadSize;
        }


        public void CreateCsvFile(IEnumerable<StimmeRaw> stimme, string filename)
        {
            InsertIntoFile("gewaehlt_id;kandidat_id\n", filename);

            var bulk = new StringBuilder();
            uint size = 0;
            foreach (var s in stimme)
            {
                for (int i = 0; i < s.Stimmen; i++)
                {
                    bulk.Append(this.GetCsvLine(s));
                    size++;
                    if (size >= this._ramBulkLoadSize)
                    {
                        this.InsertIntoFile(bulk.ToString(), filename);
                        Console.WriteLine("Inserted " + size + " values into \n\n" + filename + "\n\n\n\n\n\n\n");
                        bulk = new StringBuilder();
                        size = 0;
                    }
                }
            }
            if (bulk.Length > 0)
            {
                this.InsertIntoFile(bulk.ToString(), filename);
                Console.WriteLine("Inserted " + size + " values into \n\n" + filename + "\n\n\n\n\n\n\n");
            }
        }


        private void InsertIntoFile(string bulkString, string filename)
        {
            var writer = new StreamWriter(filename, true);
            writer.Write(bulkString);
            writer.Close();
        }


        private StringBuilder GetCsvLine(StimmeRaw s)
        {
            StringBuilder entry = new StringBuilder();
            if (s.HatGewaehlt == -1)
            {
                entry.Append(s.WahlkreisId + ";" + "\n");
            }
            else
            {
                entry.Append(s.WahlkreisId + ";" + s.HatGewaehlt + "\n");
            }
            return entry;
        }
    }
}