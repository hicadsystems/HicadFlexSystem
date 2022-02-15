using Flex.Data.Enum;
using Flex.Data.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Flex.Data.ViewModel
{
    public class UserAuthResponseViewModel
    {
        public UserAuthViewModel User { get; set; }

        public string Token { get; set; }

        public bool IsFirst { get; set; }

        public bool IsExpired { get; set; }

        public DateTime? Expires { get; set; }

        public int SessionTimeout { get; set; }

        public AuthStatus Status { get; set; }
    }

    public class UserAuthViewModel
    {
        public long Id { get; set; }

        public String Name { get; set; }

        public String Email { get; set; }

        public string Mobile { get; set; }

        public string Username { get; set; }

        public string LastName { get; set; }

        public int Branch { get; set; }

        public string Dept { get; set;}

        public UserRole UserRole { get; set; }

        public UserStatus Status { get; set; }

    }

}
