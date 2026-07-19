using System;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;

namespace PSModule
{
    public static partial class Sodium
    {
        private static partial class Native
        {
            [LibraryImport("libsodium")]
            [DefaultDllImportSearchPaths(DllImportSearchPath.AssemblyDirectory | DllImportSearchPath.SafeDirectories)]
            [UnmanagedCallConv(CallConvs = new[] { typeof(System.Runtime.CompilerServices.CallConvCdecl) })]
            public static partial int sodium_init();

            [LibraryImport("libsodium")]
            [DefaultDllImportSearchPaths(DllImportSearchPath.AssemblyDirectory | DllImportSearchPath.SafeDirectories)]
            [UnmanagedCallConv(CallConvs = new[] { typeof(System.Runtime.CompilerServices.CallConvCdecl) })]
            public static partial int crypto_box_keypair([Out] byte[] publicKey, [Out] byte[] privateKey);

            [LibraryImport("libsodium")]
            [DefaultDllImportSearchPaths(DllImportSearchPath.AssemblyDirectory | DllImportSearchPath.SafeDirectories)]
            [UnmanagedCallConv(CallConvs = new[] { typeof(System.Runtime.CompilerServices.CallConvCdecl) })]
            public static partial int crypto_box_seed_keypair([Out] byte[] publicKey, [Out] byte[] privateKey, byte[] seed);

            [LibraryImport("libsodium")]
            [DefaultDllImportSearchPaths(DllImportSearchPath.AssemblyDirectory | DllImportSearchPath.SafeDirectories)]
            [UnmanagedCallConv(CallConvs = new[] { typeof(System.Runtime.CompilerServices.CallConvCdecl) })]
            public static partial int crypto_box_seal([Out] byte[] ciphertext, byte[] message, ulong mlen, byte[] publicKey);

            [LibraryImport("libsodium")]
            [DefaultDllImportSearchPaths(DllImportSearchPath.AssemblyDirectory | DllImportSearchPath.SafeDirectories)]
            [UnmanagedCallConv(CallConvs = new[] { typeof(System.Runtime.CompilerServices.CallConvCdecl) })]
            public static partial int crypto_box_seal_open([Out] byte[] decrypted, byte[] ciphertext, ulong ciphertextLength, byte[] publicKey, byte[] privateKey);

            [LibraryImport("libsodium")]
            [DefaultDllImportSearchPaths(DllImportSearchPath.AssemblyDirectory | DllImportSearchPath.SafeDirectories)]
            [UnmanagedCallConv(CallConvs = new[] { typeof(System.Runtime.CompilerServices.CallConvCdecl) })]
            public static partial UIntPtr crypto_box_publickeybytes();

            [LibraryImport("libsodium")]
            [DefaultDllImportSearchPaths(DllImportSearchPath.AssemblyDirectory | DllImportSearchPath.SafeDirectories)]
            [UnmanagedCallConv(CallConvs = new[] { typeof(System.Runtime.CompilerServices.CallConvCdecl) })]
            public static partial UIntPtr crypto_box_secretkeybytes();

            [LibraryImport("libsodium")]
            [DefaultDllImportSearchPaths(DllImportSearchPath.AssemblyDirectory | DllImportSearchPath.SafeDirectories)]
            [UnmanagedCallConv(CallConvs = new[] { typeof(System.Runtime.CompilerServices.CallConvCdecl) })]
            public static partial UIntPtr crypto_box_sealbytes();

            [LibraryImport("libsodium")]
            [DefaultDllImportSearchPaths(DllImportSearchPath.AssemblyDirectory | DllImportSearchPath.SafeDirectories)]
            [UnmanagedCallConv(CallConvs = new[] { typeof(System.Runtime.CompilerServices.CallConvCdecl) })]
            public static partial UIntPtr crypto_box_seedbytes();

            [LibraryImport("libsodium")]
            [DefaultDllImportSearchPaths(DllImportSearchPath.AssemblyDirectory | DllImportSearchPath.SafeDirectories)]
            [UnmanagedCallConv(CallConvs = new[] { typeof(System.Runtime.CompilerServices.CallConvCdecl) })]
            public static partial int crypto_scalarmult_base([Out] byte[] publicKey, byte[] privateKey);
        }

        // libsodium guarantees these *_bytes() functions return constants and are safe to call without sodium_init().
        private static readonly int PublicKeyBytes = GetRequiredLength(Native.crypto_box_publickeybytes());
        private static readonly int SecretKeyBytes = GetRequiredLength(Native.crypto_box_secretkeybytes());
        private static readonly int SealBytes = GetRequiredLength(Native.crypto_box_sealbytes());
        private static readonly int SeedBytes = GetRequiredLength(Native.crypto_box_seedbytes());

        public static int sodium_init()
        {
            return Native.sodium_init();
        }

        public static int crypto_box_keypair(byte[] publicKey, byte[] privateKey)
        {
            ValidateMinimumBufferLength(publicKey, PublicKeyBytes, nameof(publicKey));
            ValidateMinimumBufferLength(privateKey, SecretKeyBytes, nameof(privateKey));

            return Native.crypto_box_keypair(publicKey, privateKey);
        }

        public static int crypto_box_seed_keypair(byte[] publicKey, byte[] privateKey, byte[] seed)
        {
            ValidateMinimumBufferLength(publicKey, PublicKeyBytes, nameof(publicKey));
            ValidateMinimumBufferLength(privateKey, SecretKeyBytes, nameof(privateKey));
            ValidateExactBufferLength(seed, SeedBytes, nameof(seed));

            return Native.crypto_box_seed_keypair(publicKey, privateKey, seed);
        }

        public static int crypto_box_seal(byte[] ciphertext, byte[] message, ulong mlen, byte[] publicKey)
        {
            ValidateMinimumBufferLength(message, mlen, nameof(message));
            ValidateMinimumBufferLength(ciphertext, checked(mlen + (ulong)SealBytes), nameof(ciphertext));
            ValidateExactBufferLength(publicKey, PublicKeyBytes, nameof(publicKey));

            return Native.crypto_box_seal(ciphertext, message, mlen, publicKey);
        }

        public static int crypto_box_seal_open(byte[] decrypted, byte[] ciphertext, ulong ciphertextLength, byte[] publicKey, byte[] privateKey)
        {
            var sealBytes = (ulong)SealBytes;
            if (ciphertextLength < sealBytes)
            {
                throw new ArgumentException($"The ciphertext must be at least {sealBytes} bytes.", nameof(ciphertext));
            }

            ValidateMinimumBufferLength(ciphertext, ciphertextLength, nameof(ciphertext));
            ValidateMinimumBufferLength(decrypted, ciphertextLength - sealBytes, nameof(decrypted));
            ValidateExactBufferLength(publicKey, PublicKeyBytes, nameof(publicKey));
            ValidateExactBufferLength(privateKey, SecretKeyBytes, nameof(privateKey));

            return Native.crypto_box_seal_open(decrypted, ciphertext, ciphertextLength, publicKey, privateKey);
        }

        public static UIntPtr crypto_box_publickeybytes()
        {
            return (UIntPtr)PublicKeyBytes;
        }

        public static UIntPtr crypto_box_secretkeybytes()
        {
            return (UIntPtr)SecretKeyBytes;
        }

        public static UIntPtr crypto_box_sealbytes()
        {
            return (UIntPtr)SealBytes;
        }

        public static UIntPtr crypto_box_seedbytes()
        {
            return (UIntPtr)SeedBytes;
        }

        public static int crypto_scalarmult_base(byte[] publicKey, byte[] privateKey)
        {
            ValidateMinimumBufferLength(publicKey, PublicKeyBytes, nameof(publicKey));
            ValidateExactBufferLength(privateKey, SecretKeyBytes, nameof(privateKey));

            return Native.crypto_scalarmult_base(publicKey, privateKey);
        }

        // ---------- Base64-centric high-level API (see issue #52) ----------
        // These helpers do base64/UTF-8 encoding and native interop in a single managed call,
        // avoiding the overhead of multiple PowerShell-level method invocations on the hot path.

        public sealed class KeyPairBase64
        {
            public string PublicKey { get; }
            public string PrivateKey { get; }

            internal KeyPairBase64(string publicKey, string privateKey)
            {
                PublicKey = publicKey;
                PrivateKey = privateKey;
            }
        }

        public static KeyPairBase64 GenerateKeyPairBase64()
        {
            var publicKey = new byte[PublicKeyBytes];
            var privateKey = new byte[SecretKeyBytes];
            try
            {
                if (Native.crypto_box_keypair(publicKey, privateKey) != 0)
                {
                    throw new InvalidOperationException("Key pair generation failed.");
                }
                return new KeyPairBase64(Convert.ToBase64String(publicKey), Convert.ToBase64String(privateKey));
            }
            finally
            {
                CryptographicOperations.ZeroMemory(privateKey);
            }
        }

        public static KeyPairBase64 GenerateKeyPairBase64(string seedText)
        {
            ArgumentNullException.ThrowIfNull(seedText);
            var publicKey = new byte[PublicKeyBytes];
            var privateKey = new byte[SecretKeyBytes];
            var seedSource = Encoding.UTF8.GetBytes(seedText);
            var seed = new byte[SeedBytes];
            try
            {
                if (!SHA256.TryHashData(seedSource, seed, out var written) || written != SeedBytes)
                {
                    throw new InvalidOperationException("Failed to derive seed bytes from input.");
                }
                if (Native.crypto_box_seed_keypair(publicKey, privateKey, seed) != 0)
                {
                    throw new InvalidOperationException("Seeded key pair generation failed.");
                }
                return new KeyPairBase64(Convert.ToBase64String(publicKey), Convert.ToBase64String(privateKey));
            }
            finally
            {
                CryptographicOperations.ZeroMemory(privateKey);
                CryptographicOperations.ZeroMemory(seed);
                CryptographicOperations.ZeroMemory(seedSource);
            }
        }

        public static string DerivePublicKeyBase64(string privateKeyBase64)
        {
            return Convert.ToBase64String(DerivePublicKey(privateKeyBase64));
        }

        public static byte[] DerivePublicKey(string privateKeyBase64)
        {
            ArgumentNullException.ThrowIfNull(privateKeyBase64);
            var privateKey = DecodeBase64Exact(privateKeyBase64, SecretKeyBytes, "private key");
            var publicKey = new byte[PublicKeyBytes];
            try
            {
                if (Native.crypto_scalarmult_base(publicKey, privateKey) != 0)
                {
                    throw new InvalidOperationException("Unable to derive public key from private key.");
                }
                return publicKey;
            }
            finally
            {
                CryptographicOperations.ZeroMemory(privateKey);
            }
        }

        public static string SealBase64(string plaintext, string publicKeyBase64)
        {
            ArgumentNullException.ThrowIfNull(plaintext);
            ArgumentNullException.ThrowIfNull(publicKeyBase64);
            var publicKey = DecodeBase64Exact(publicKeyBase64, PublicKeyBytes, "public key");
            var message = Encoding.UTF8.GetBytes(plaintext);
            var ciphertext = new byte[message.Length + SealBytes];
            try
            {
                if (Native.crypto_box_seal(ciphertext, message, (ulong)message.LongLength, publicKey) != 0)
                {
                    throw new InvalidOperationException("Encryption failed.");
                }
                return Convert.ToBase64String(ciphertext);
            }
            finally
            {
                CryptographicOperations.ZeroMemory(message);
            }
        }

        public static string OpenSealBase64(string ciphertextBase64, string privateKeyBase64)
        {
            return OpenSealBase64Core(ciphertextBase64, privateKeyBase64, publicKeyBase64: null);
        }

        public static string OpenSealBase64(string ciphertextBase64, string privateKeyBase64, string publicKeyBase64)
        {
            return OpenSealBase64Core(ciphertextBase64, privateKeyBase64, publicKeyBase64);
        }

        private static string OpenSealBase64Core(string ciphertextBase64, string privateKeyBase64, string publicKeyBase64)
        {
            ArgumentNullException.ThrowIfNull(ciphertextBase64);
            ArgumentNullException.ThrowIfNull(privateKeyBase64);

            var ciphertext = Convert.FromBase64String(ciphertextBase64);
            if (ciphertext.Length < SealBytes)
            {
                throw new ArgumentException($"Invalid sealed box. Expected at least {SealBytes} bytes but got {ciphertext.Length}.");
            }
            var privateKey = DecodeBase64Exact(privateKeyBase64, SecretKeyBytes, "private key");
            var publicKey = new byte[PublicKeyBytes];
            var decrypted = new byte[ciphertext.Length - SealBytes];
            try
            {
                if (string.IsNullOrEmpty(publicKeyBase64))
                {
                    if (Native.crypto_scalarmult_base(publicKey, privateKey) != 0)
                    {
                        throw new InvalidOperationException("Unable to derive public key from private key.");
                    }
                }
                else
                {
                    var providedPk = DecodeBase64Exact(publicKeyBase64, PublicKeyBytes, "public key");
                    Buffer.BlockCopy(providedPk, 0, publicKey, 0, PublicKeyBytes);
                }

                if (Native.crypto_box_seal_open(decrypted, ciphertext, (ulong)ciphertext.LongLength, publicKey, privateKey) != 0)
                {
                    throw new InvalidOperationException("Decryption failed.");
                }
                return Encoding.UTF8.GetString(decrypted);
            }
            finally
            {
                CryptographicOperations.ZeroMemory(privateKey);
                CryptographicOperations.ZeroMemory(decrypted);
            }
        }

        private static byte[] DecodeBase64Exact(string value, int expectedLength, string label)
        {
            var bytes = Convert.FromBase64String(value);
            if (bytes.Length != expectedLength)
            {
                throw new ArgumentException($"Invalid {label}. Expected {expectedLength} bytes but got {bytes.Length}.");
            }
            return bytes;
        }

        private static int GetRequiredLength(UIntPtr length)
        {
            var value = length.ToUInt64();
            if (value > int.MaxValue)
            {
                throw new OverflowException("The Sodium buffer length exceeds the maximum supported array length.");
            }

            return (int)value;
        }

        private static void ValidateExactBufferLength(byte[] buffer, int expectedLength, string parameterName)
        {
            ArgumentNullException.ThrowIfNull(buffer, parameterName);

            if (buffer.Length != expectedLength)
            {
                throw new ArgumentException($"The buffer must be exactly {expectedLength} bytes.", parameterName);
            }
        }

        private static void ValidateMinimumBufferLength(byte[] buffer, int minimumLength, string parameterName)
        {
            ValidateMinimumBufferLength(buffer, (ulong)minimumLength, parameterName);
        }

        private static void ValidateMinimumBufferLength(byte[] buffer, ulong minimumLength, string parameterName)
        {
            ArgumentNullException.ThrowIfNull(buffer, parameterName);

            if ((ulong)buffer.LongLength < minimumLength)
            {
                throw new ArgumentException($"The buffer must be at least {minimumLength} bytes.", parameterName);
            }
        }
    }
}
