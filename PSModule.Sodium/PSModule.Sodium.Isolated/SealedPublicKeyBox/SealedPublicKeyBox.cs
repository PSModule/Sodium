
using Sodium;

namespace PSModule.Sodium.Isolated
{
    public class SealedPublicKeyBoxHelper
    {
        public static byte[] Create(byte[] secret, byte[] publicKey)
        {
            return SealedPublicKeyBox.Create(secret, publicKey);
        }

        public static byte[] Open(byte[] cipher, byte[] publicKey, byte[] secretKey)
        {
            return SealedPublicKeyBox.Open(cipher, publicKey, secretKey);
        }
    }
}
