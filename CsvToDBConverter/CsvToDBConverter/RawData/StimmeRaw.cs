using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using LINQtoCSV;

namespace CsvToDBConverter.RawData
{
    class StimmeRaw
    {

        [CsvColumn(Name = "hatGewaehlt", FieldIndex = 1)]
        public int HatGewaehlt { get; set; }

        [CsvColumn(Name = "wahlkreisId", FieldIndex = 2)]
        public int WahlkreisId { get; set; }

        [CsvColumn(Name = "stimmen", FieldIndex = 3)]
        public int Stimmen { get; set; }


        public StimmeRaw(){}

        public StimmeRaw (int hatGewaehlt, int wahlkreisId, int stimmen)
        {
            this.HatGewaehlt = hatGewaehlt;
            this.WahlkreisId = wahlkreisId;
            this.Stimmen = stimmen;
        }


        
        

        
       
    }
}
