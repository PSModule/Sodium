using PSModule.Sodium.Isolated;
using Sodium;

namespace PSModule.Sodium.Isolated
{
    public class SealedPublicKeyBoxHelper
    {
        public static byte[] Create(byte[] secret, byte[] publicKey)
        {
            return SealedPublicKeyBox.Create(secret, publicKey);
        }

        public static byte[] Open(byte[] secret, byte[] privateKey, byte[] publicKey)
        {
            return SealedPublicKeyBox.Open(secret, privateKey, publicKey);
        }
    }
}
