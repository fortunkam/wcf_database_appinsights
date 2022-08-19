using PeopleService.Models;
using PeopleService.Services;
using System;

namespace PeopleService
{
    // NOTE: You can use the "Rename" command on the "Refactor" menu to change the class name "Service1" in code, svc and config file together.
    // NOTE: In order to launch WCF Test Client for testing this service, please select Service1.svc or Service1.svc.cs at the Solution Explorer and start debugging.
    public class PersonRetriever : IPersonRetriever
    {
        private readonly IPersonRepository _personRepository;

        public PersonRetriever()
        {
            _personRepository = new PersonRepository();
        }
        public Person GetPersonByName(string firstName)
        {
            return _personRepository.GetPersonByName(firstName); 
        }

        public Person[] GetPeople()
        {
            return _personRepository.GetPeople();   
        }

        public Person GetPersonById(int id)
        {
            return _personRepository.GetPersonById(id); 
        }
    }
}
