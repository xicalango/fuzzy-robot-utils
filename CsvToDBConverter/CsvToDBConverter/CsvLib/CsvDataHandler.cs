using System.Collections.Generic;
using LINQtoCSV;

namespace CsvToDBConverter.CsvLib
{
    class CsvDataHandler
    {

        private readonly CsvFileDescription _inputFileDescription;
        private readonly CsvFileDescription _outputFileDescription;

        public CsvDataHandler(char separator, bool firstLineHasColumnNames)
        {
            this._inputFileDescription = new CsvFileDescription
                                                          {
                                                              SeparatorChar =  separator,
                                                              FirstLineHasColumnNames = firstLineHasColumnNames
                                                          };
            this._outputFileDescription = new CsvFileDescription
                                              {
                                                  SeparatorChar = separator,
                                                  FirstLineHasColumnNames = true,
                                              };
        }


        public IEnumerable<T> ReadFromCsv<T>(string file)
            where T : class, new()
        {
            var cc = new CsvContext();
            IEnumerable<T> enumeration =
            cc.Read<T>(file, this._inputFileDescription);
            return enumeration;
        }


        public void WriteToCsv<T>(IEnumerable<T> toWrite, string file)
        {
            var cc = new CsvContext();
            cc.Write(toWrite, file,this._outputFileDescription);
        }


      
    }
}
