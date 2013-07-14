//
//  NSData+Encryption.m
//  CameraShy
//
//  Created by Daniel DeCovnick on 9/15/12.
//  Copyright (c) 2012 Softyards Software. All rights reserved.
//

#import "NSData+Encryption.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>

@implementation NSData (Encryption)
NSString * const SYCryptoManagerErrorDomain = @"com.softyards.cryptoErrorDomain";

const CCAlgorithm kAlgorithm = kCCAlgorithmAES128;
const NSUInteger kAlgorithmKeySize = kCCKeySizeAES256;
const NSUInteger kAlgorithmBlockSize = kCCBlockSizeAES128;
const NSUInteger kAlgorithmIVSize = kCCBlockSizeAES128;
const NSUInteger kPBKDFSaltSize = 8;
const NSUInteger kPBKDFRounds = 10000;  // ~80ms on an iPhone 4

// ===================

+ (NSData *)encryptedDataForData:(NSData *)data
                        password:(NSString *)password
                              iv:(NSData **)iv
                            salt:(NSData **)salt
                           error:(NSError **)error {
    NSAssert(iv, @"IV must not be NULL");
    NSAssert(salt, @"salt must not be NULL");
    NSAssert(iv != salt, @"Don't be stupid");
    
    if (*iv == nil)
    {
        *iv = [self randomDataOfLength:kAlgorithmIVSize];
    }
    if (*salt == nil)
    {
        *salt = [self randomDataOfLength:kPBKDFSaltSize]; //this may be a bad idea
    }
    
    NSData *key = [self AESKeyForPassword:password salt:*salt];
    
    size_t outLength;
    NSMutableData *cipherData = [NSMutableData dataWithLength:data.length + kAlgorithmBlockSize];
    
    CCCryptorStatus
    result = CCCrypt(kCCEncrypt, // operation
                     kAlgorithm, // Algorithm
                     kCCOptionPKCS7Padding, // options
                     key.bytes, // key
                     key.length, // keylength
                     (*iv).bytes,// iv
                     data.bytes, // dataIn
                     data.length, // dataInLength,
                     cipherData.mutableBytes, // dataOut
                     cipherData.length, // dataOutAvailable
                     &outLength); // dataOutMoved
    
    if (result == kCCSuccess) {
        cipherData.length = outLength;
    }
    else {
        if (error) {
            *error = [NSError errorWithDomain:SYCryptoManagerErrorDomain
                                         code:result
                                     userInfo:nil];
        }
        return nil;
    }
    
    return cipherData;
}

+ (NSData *)decryptedDataForData:(NSData *)data
                        password:(NSString *)password
                              iv:(NSData *)iv
                            salt:(NSData *)salt
                           error:(NSError **)error
{
    NSData *key = [self AESKeyForPassword:password salt:salt];
    
    size_t outLength;
    NSMutableData *clearData = [NSMutableData dataWithLength:data.length];
    CCCryptorStatus result = CCCrypt(kCCDecrypt, 
                                     kAlgorithm, 
                                     kCCOptionPKCS7Padding, 
                                     key.bytes, 
                                     key.length, 
                                     iv.bytes, 
                                     data.bytes, 
                                     data.length, 
                                     clearData.mutableBytes, 
                                     clearData.length, 
                                     &outLength);
    if (result == kCCSuccess)
    {
        [clearData setLength:outLength];
    }
    else
    {
        if (error != NULL)
        {
            *error = [NSError errorWithDomain:SYCryptoManagerErrorDomain code:result userInfo:nil];
        }
        return nil;
    }
    return clearData;
}

// ===================

+ (NSData *)randomDataOfLength:(size_t)length {
    NSMutableData *data = [NSMutableData dataWithLength:length];
    
    int result = SecRandomCopyBytes(kSecRandomDefault, 
                                    length,
                                    data.mutableBytes);
    NSAssert(result == 0, @"Unable to generate random bytes: %d",
             errno);
    
    return data;
}

// ===================

// Replace this with a 10,000 hash calls if you don't have CCKeyDerivationPBKDF
+ (NSData *)AESKeyForPassword:(NSString *)password 
                         salt:(NSData *)salt {
    NSMutableData *
    derivedKey = [NSMutableData dataWithLength:kAlgorithmKeySize];
    
    int 
    result = CCKeyDerivationPBKDF(kCCPBKDF2,            // algorithm
                                  password.UTF8String,  // password
                                  password.length,  // passwordLength
                                  salt.bytes,           // salt
                                  salt.length,          // saltLen
                                  kCCPRFHmacAlgSHA1,    // PRF
                                  kPBKDFRounds,         // rounds
                                  derivedKey.mutableBytes, // derivedKey
                                  derivedKey.length); // derivedKeyLen
    
    // Do not log password here
    NSAssert(result == kCCSuccess,
             @"Unable to create AES key for password: %d", result);
    
    return derivedKey;
}

@end
