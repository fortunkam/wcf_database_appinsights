using PeopleService.Models;

namespace PeopleService.Services
{
    public interface IPersonRepository
    {
        Person GetPersonByName(string firstName);
        Person[] GetPeople();
        Person GetPersonById(int id);
    }
}