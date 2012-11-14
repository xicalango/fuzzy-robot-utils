using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Npgsql;

namespace CsvToDBConverter.Database
{
    internal class PostgresqlConnector
    {

       
        private readonly string _connectionString;
        private NpgsqlConnection _connection;


        public PostgresqlConnector(string host, string port, string userId, string password, string databaseName)
        {
            this._connectionString = String.Format("Server={0};Port={1};" + "User Id={2};Password={3};Database={4}", host, port, userId, password, databaseName);


        }
 
        public DataSet ExecuteCommand(string command)
        {
            this.EstablishDatabaseConnection();

            var dataAdapter = new NpgsqlDataAdapter(command, this._connection);

            var dataSet = new DataSet();
            try
            {
                dataAdapter.Fill(dataSet);
            }
            catch (Exception)
            {
                
                Console.WriteLine("Fehler bei ausführen des SQL-Querys...");
            }
            finally
            {
                this.CloseDatabaseConnection();
            }
            
            return dataSet;
        }

        private void EstablishDatabaseConnection()
        {
            this._connection = new NpgsqlConnection(this._connectionString);
            _connection.Open();
        }

        private void CloseDatabaseConnection()
        {
            this._connection.Close();
        }
    
    }
}
