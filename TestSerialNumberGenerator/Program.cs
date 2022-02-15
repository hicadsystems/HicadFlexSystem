using SerialNumber;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TestSerialNumberGenerator
{
    class Program
    {
        static void Main(string[] args)
        {
            var sno = new SerialNumberSource().GetNextNumber("01");
            Console.Write(sno);
            Console.ReadKey();
        }
    }
}
