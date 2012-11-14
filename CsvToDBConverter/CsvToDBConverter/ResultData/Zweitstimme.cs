using LINQtoCSV;

namespace CsvToDBConverter.ResultData
{
    class Zweitstimme
    {
        [CsvColumn(Name = "wahlkreis_id", FieldIndex = 1)]
        public int WahlkreisId { get; set; }

        [CsvColumn(Name = "landesliste_id", FieldIndex = 2)]
        public int LandeslisteId { get; set; }

    }
}
