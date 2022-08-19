using Dapper;
using PeopleService.Models;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;

namespace PeopleService.Services
{
    public class PersonRepository : IPersonRepository
    {
        private readonly string _connectionString;

        public PersonRepository()
        {
            _connectionString = ConfigurationManager.ConnectionStrings["PeopleDatabaseConnectionString"].ConnectionString;
        }
        public Person GetPersonByName(string firstName)
        {
            using (var sqlConnection = new SqlConnection(_connectionString))
            {
                sqlConnection.Open();
                var result = sqlConnection.Query("SELECT id, firstname FROM dbo.People WHERE firstname = @FirstName",
                    new { FirstName = firstName }, commandType: CommandType.Text)
                    .First();

                return new Person() { Id = result.id, FirstName = result.firstname };
            }
        }

        public Person[] GetPeople()
        {
            using (var sqlConnection = new SqlConnection(_connectionString))
            {
                sqlConnection.Open();
                var results = sqlConnection.Query("getPeople", commandType: CommandType.StoredProcedure)
                    .ToList();

                return results.Select(r => new Person() { Id = r.id, FirstName = r.firstname }).ToArray();
            }
        }

        public Person GetPersonById(int id)
        {
            using (var sqlConnection = new SqlConnection(_connectionString))
            {
                sqlConnection.Open();
                var result = sqlConnection.Query("getPersonById", new { id = id }, commandType: CommandType.StoredProcedure)
                    .First();

                return new Person() { Id = result.id, FirstName = result.firstname };
            }
        }
    }
}