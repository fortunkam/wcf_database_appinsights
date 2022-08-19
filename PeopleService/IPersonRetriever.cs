using System.ServiceModel;
using PeopleService.Models;

namespace PeopleService
{
    [ServiceContract]
    public interface IPersonRetriever
    {

        [OperationContract]
        Person GetPersonByName(string firstName);

        [OperationContract]
        Person[] GetPeople();

        [OperationContract]
        Person GetPersonById(int id);
    }
}
