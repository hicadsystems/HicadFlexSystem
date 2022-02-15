using Flex.Data.Enum;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flex.Data.ViewModel
{
    public class MessageViewModel
    {
        public MessageType MessageType { get; set; }

        public NotificationType NotificationType { get; set; }

        public string Message { get; set; }

        public bool IsEnabled { get; set; }

        public string PolicyType { get; set; }

        public List<string> PolicyTypes
        {
            get
            {
                return this.PolicyType.Split(new char[] { ';' }, StringSplitOptions.RemoveEmptyEntries).ToList();
            }
        }
    }
}
