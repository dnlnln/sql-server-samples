using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataGenerator
{
    public class SqlDataGeneratorException : Exception
    {
        public SqlDataGeneratorException()
            :base()
        {
        }

        public SqlDataGeneratorException(string message)
            :base(message)
        {
        }

        public SqlDataGeneratorException(string message, Exception innerException)
            : base(message, innerException)
        {
        }
    }
}
