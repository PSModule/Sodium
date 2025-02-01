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
            (byte[] publicKey, byte[] privateKey) = PublicKeyBox.GenerateKeyPair();
            var publicKeyString = Convert.ToBase64String(publicKey);
            var privateKeyString = Convert.ToBase64String(privateKey);
            WriteObject(new { PublicKey = publicKeyString, PrivateKey = privateKeyString });
        }
    }
}
