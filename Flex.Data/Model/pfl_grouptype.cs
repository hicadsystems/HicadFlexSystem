using Flex.Data.Enum;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Flex.Data.Model
{
    public partial class fl_grouptype
    {
        public IList<string> Class 
        {
            get 
            {
                string[] grpclass = new string[] { "" };
                string[] splitter = { ";" };
                return this.grpclass != null ? this.grpclass.Split(splitter, StringSplitOptions.RemoveEmptyEntries).ToList() : grpclass.ToList();
            }
        
        }

        public string grpClassName
        {
            get
            {
                var classname = string.Empty;
                if (!string.IsNullOrEmpty(this.Class.FirstOrDefault()))
                {
                    foreach (var cl in this.Class)
                    {
                        classname += ((GroupClass)System.Enum.Parse(typeof(GroupClass), cl)).ToString() + ";";
                    } 
                }
                return classname;
            }

        }
    }
}
