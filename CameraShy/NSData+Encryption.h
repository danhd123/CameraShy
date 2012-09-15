//
//  NSData+Encryption.h
//  CameraShy
//
//  Created by Daniel DeCovnick on 9/15/12.
//  Copyright (c) 2012 Softyards Software. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString * const SYCryptoManagerErrorDomain;

@interface NSData (Encryption)
+ (NSData *)encryptedDataForData:(NSData *)data
                        password:(NSString *)password
                              iv:(NSData **)iv
                            salt:(NSData **)salt
                           error:(NSError **)error;

+ (NSData *)decryptedDataForData:(NSData *)data
                        password:(NSString *)password
                              iv:(NSData *)iv
                            salt:(NSData *)salt
                           error:(NSError **)error;

+ (NSData *)randomDataOfLength:(size_t)length;

+ (NSData *)AESKeyForPassword:(NSString *)password 
                         salt:(NSData *)salt;

@end
