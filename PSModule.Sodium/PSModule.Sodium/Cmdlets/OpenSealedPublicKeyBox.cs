using System;
using System.Text;
using System.Management.Automation;
using System.Security;
using PSModule.Sodium.Isolated;

namespace PSModule.Sodium
{
    [Cmdlet(VerbsCommon.Open, "SealedPublicKeyBox")]
    [OutputType(typeof(string))]
    public class OpenSealedPublicKeyBoxCommand : PSCmdlet
    {
        [Parameter(Mandatory = true)]
        public string EncryptedSecret { get; set; }

        [Parameter(Mandatory = true)]
        public string PublicKey { get; set; }

        [Parameter(Mandatory = true)]
        public string PrivateKey { get; set; }

        protected override void ProcessRecord()
        {
            var decryptedString = Encoding.UTF8.GetString(
                SealedPublicKeyBoxHelper.Open(
                    Convert.FromBase64String(EncryptedSecret),
                    Convert.FromBase64String(PrivateKey),
                    Convert.FromBase64String(PublicKey)
                )
            );
            WriteObject(decryptedString);
        }
    }
}
