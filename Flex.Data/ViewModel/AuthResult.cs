using Flex.Data.Enum;
using Flex.Data.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Flex.Data.ViewModel
{
    public class AuthResult
    {
        public AuthStatus Status { get; set; }
        public String Description { get; set; }

        public UserSession Session { get; set; }
    }

}
