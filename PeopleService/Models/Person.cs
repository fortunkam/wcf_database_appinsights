using System.Runtime.Serialization;

namespace PeopleService.Models
{
    // Use a data contract as illustrated in the sample below to add composite types to service operations.
    [DataContract]
    public class Person
    {
        [DataMember]
        public int Id { get; set; }

        [DataMember]
        public string FirstName { get; set; }
    }
}
