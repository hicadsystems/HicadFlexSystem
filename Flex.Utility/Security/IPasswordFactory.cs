using System;

namespace Flex.Utility.Security
{
	/// <summary>
	/// Summary description for IPasswordFactory.
	/// </summary>
	public interface IPasswordFactory 
	{
		string CreateSecurePassword(string clearPassword);
		
		string GetPasswordInClear(string securePassword);

	}
}
