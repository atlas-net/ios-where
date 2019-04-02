//
//  FSNetworkingCommunicator.m
//  FSNetworkingSearchController
//
//  Created by alexruperez on 30/3/15.
//
//

#import "FSNetworkingCommunicator.h"


@interface FSNConnection (Communicator)

@property (nonatomic, strong, readwrite) NSError *error;

@end

@implementation FSNetworkingCommunicator

#pragma mark - FSNetworkingCommunicatorProtocol

- (FSNConnection *)startWithUrl:(NSURL *)url completionBlock:(FSNCompletionBlock)completionBlock
{
    return [self startWithUrl:url method:FSNRequestMethodGET headers:nil parameters:nil parseBlock:nil completionBlock:completionBlock progressBlock:nil];
}

- (FSNConnection *)startWithUrl:(NSURL *)url method:(FSNRequestMethod)method headers:(NSDictionary*)headers parameters:(NSDictionary*)parameters parseBlock:(FSNParseBlock)parseBlock completionBlock:(FSNCompletionBlock)completionBlock progressBlock:(FSNProgressBlock)progressBlock
{
    FSNConnection *connection = [FSNConnection withUrl:url method:method headers:headers parameters:parameters parseBlock:^id(FSNConnection *connection, NSError *__autoreleasing *error) {
        if (parseBlock)
        {
            return parseBlock(connection, error);
        }
        
        return [connection.responseData dictionaryFromJSONWithError:error];
    } completionBlock:^(FSNConnection *connection) {
        id object = connection.parseResult;
        if (object[@"meta"][@"errorDetail"])
        {
            connection.error = [NSError errorWithDomain:FSNConnectionErrorDomain code:[object[@"meta"][@"code"] intValue] userInfo:@{NSLocalizedDescriptionKey: object[@"meta"][@"errorDetail"]}];
        }
        if (completionBlock)
        {
            completionBlock(connection);
        }
    } progressBlock:progressBlock];
    
    [connection start];
    
    return connection;
}

@end
