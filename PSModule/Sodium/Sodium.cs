using System;
using System.Runtime.InteropServices;

namespace PSModule
{
    public static class Sodium
    {
        [DllImport("libsodium", CallingConvention = CallingConvention.Cdecl)]
        public static extern int sodium_init();

        [DllImport("libsodium", CallingConvention = CallingConvention.Cdecl)]
        public static extern int crypto_box_keypair(byte[] publicKey, byte[] privateKey);

        [DllImport("libsodium", CallingConvention = CallingConvention.Cdecl)]
        public static extern int crypto_box_seed_keypair(byte[] publicKey, byte[] privateKey, byte[] seed);

        [DllImport("libsodium", CallingConvention = CallingConvention.Cdecl)]
        public static extern int crypto_box_seal(byte[] ciphertext, byte[] message, ulong mlen, byte[] publicKey);

        [DllImport("libsodium", CallingConvention = CallingConvention.Cdecl)]
        public static extern int crypto_box_seal_open(byte[] decrypted, byte[] ciphertext, ulong clen, byte[] publicKey, byte[] privateKey);

        [DllImport("libsodium", CallingConvention = CallingConvention.Cdecl)]
        public static extern UIntPtr crypto_box_publickeybytes();

        [DllImport("libsodium", CallingConvention = CallingConvention.Cdecl)]
        public static extern UIntPtr crypto_box_secretkeybytes();

        [DllImport("libsodium", CallingConvention = CallingConvention.Cdecl)]
        public static extern UIntPtr crypto_box_sealbytes();

        [DllImport("libsodium", CallingConvention = CallingConvention.Cdecl)]
        public static extern int crypto_scalarmult_base(byte[] publicKey, byte[] privateKey);

    }
}
