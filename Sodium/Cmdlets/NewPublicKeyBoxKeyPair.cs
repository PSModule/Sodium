using System;
using System.Text;
using System.Management.Automation;
using Sodium;

namespace PSModule.Sodium
{
    [Cmdlet(VerbsCommon.New, "PublicKeyBoxKeyPair")]
    [OutputType(typeof(string))]
    public class NewPublicKeyBoxKeyPairCommand : PSCmdlet
    {
        protected override void ProcessRecord()
        {
            KeyPair keys = PublicKeyBox.GenerateKeyPair();
            var publicKeyString = Convert.ToBase64String(keys.PublicKey);
            var privateKeyString = Convert.ToBase64String(keys.PrivateKey);
            WriteObject(new { PublicKey = publicKeyString, PrivateKey = privateKeyString });
        }
    }
}
