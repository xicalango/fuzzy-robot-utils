using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CsvToDBConverter.CsvLib;
using CsvToDBConverter.Database;
using CsvToDBConverter.RawData;
using CsvToDBConverter.ResultData;

namespace CsvToDBConverter
{
    class Program
    {
        static void Main(string[] args)
        {
           
            //Create a connection to postgresql database

            var connector = new PostgresqlConnector("minitux.dyndns.org","5432", "siggi", "siggi", "btw2009");

            /*
            ImportErststimmen(connector,"C:\\Users\\Siegfried\\Desktop\\erststimmen" +
                                                    ".csv");

            ImportZweitstimmen(connector, "C:\\Users\\Siegfried\\Desktop\\zweitstimmen" +
                                                    ".csv");

            ImportStimmenFromCsvFile("C:\\Users\\Siegfried\\Desktop\\stimmen.csv", "C:\\Users\\Siegfried\\Desktop\\stimmenFertig.csv");
             */
           }


        static void ImportStimmenFromCsvFile(string readFile, string writeFile)
        {
            Console.WriteLine("Beginne mit der Stimmgenerierung...");
            var dataHandler = new CsvDataHandler(';', true);
            var erststimmenRaw = dataHandler.ReadFromCsv<StimmeRaw>(readFile);
            
            var generator = new CsvStimmenGenerator(100000);
            generator.CreateCsvFile(erststimmenRaw, writeFile);
            Console.WriteLine("\nStimmen generiert...");
        }


        static void ImportZweitstimmen(PostgresqlConnector connector, string file)
        {
            var data =
                connector.ExecuteCommand(
                    "select * from stimmen2009.landesliste_stimmen");


            var erststimmenRaw = new List<StimmeRaw>();
            int gesamtstimmen = 0;
            foreach (DataRow dataRow in data.Tables[0].Rows)
            {

                int stimmenanzahl = Convert.ToInt32(dataRow["stimmen"].ToString());

                int landesliste_id = Convert.ToInt32(dataRow["landesliste_id"].ToString());

                int wahlkreisId = Convert.ToInt32(dataRow["wahlkreis_id"].ToString());

                gesamtstimmen += stimmenanzahl;
                var s = new StimmeRaw(landesliste_id, wahlkreisId, stimmenanzahl);
                erststimmenRaw.Add(s);
            }


            //Import der ungültigen Stimmen

            data =
                connector.ExecuteCommand(
                    "select * from stimmen2009.zweitstimme_ungueltige");


            foreach (DataRow dataRow in data.Tables[0].Rows)
            {

                int stimmenanzahl = Convert.ToInt32(dataRow["stimmen"].ToString());
                int wahlkreis_id = Convert.ToInt32(dataRow["wahlkreis_id"].ToString());


                gesamtstimmen += stimmenanzahl;
                var s = new StimmeRaw(-1, wahlkreis_id, stimmenanzahl);
                erststimmenRaw.Add(s);
            }

            Console.WriteLine("Beginne mit dem Import von " + gesamtstimmen + " Stimmen...");

            var generator = new CsvStimmenGenerator(100000);
            generator.CreateCsvFile(erststimmenRaw, file);

            Console.WriteLine("\n\n\nFertig...");
        }



        static void ImportErststimmen(PostgresqlConnector connector, string file)
        {
            var data =
                connector.ExecuteCommand(
                    "select * from stimmen2009.direktkandidat_stimmen");


            var erststimmenRaw = new List<StimmeRaw>();
            int gesamtstimmen = 0;
            foreach (DataRow dataRow in data.Tables[0].Rows)
            {

                int stimmenanzahl = Convert.ToInt32(dataRow["stimmen"].ToString());

                int kandidatId = Convert.ToInt32(dataRow["kandidat_id"].ToString());

                int wahlkreisId = Convert.ToInt32(dataRow["wahlkreis_id"].ToString());

                gesamtstimmen += stimmenanzahl;
                var s = new StimmeRaw(kandidatId, wahlkreisId, stimmenanzahl);
                erststimmenRaw.Add(s);
            }


            //Import der ungültigen Stimmen

            data =
                connector.ExecuteCommand(
                    "select * from stimmen2009.erststimme_ungueltige");


            foreach (DataRow dataRow in data.Tables[0].Rows)
            {

                int stimmenanzahl = Convert.ToInt32(dataRow["stimmen"].ToString());
                int wahlkreis_id = Convert.ToInt32(dataRow["wahlkreis_id"].ToString());


                gesamtstimmen += stimmenanzahl;
                var s = new StimmeRaw(-1, wahlkreis_id, stimmenanzahl);
                erststimmenRaw.Add(s);
            }

            Console.WriteLine("Beginne mit dem Import von " + gesamtstimmen + " Stimmen...");
            
            var generator = new CsvStimmenGenerator(100000);
            generator.CreateCsvFile(erststimmenRaw, file);

            Console.WriteLine("\n\n\nFertig...");
        }
    }
}
