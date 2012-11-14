using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CsvToDBConverter.RawData
{
    class StimmeRaw
    {


        private readonly int _hatGewaehltId;
        private readonly int _wahlkreisId;
        private readonly int _stimmen;




        public StimmeRaw (int hatGewaehltId, int wahlkreisId, int stimmen)
        {
            _hatGewaehltId = hatGewaehltId;
            _wahlkreisId = wahlkreisId;
            _stimmen = stimmen;
        }

       

        public int Stimmen
        {
            get { return _stimmen; }
        }

        public int HatGewaehltId
        {
            get { return _hatGewaehltId; }
        }

        public int WahlkreisId
        {
            get { return _wahlkreisId; }
        }
    }
}
