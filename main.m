// This is an example of how to use Objective C blocks to
// mimic yield similar to CLU and C#.
//
// Another approach is to use a more Ruby like 
// construction where the caller passes in a block of
// functionality to the iterator.
//

#import <Foundation/Foundation.h>

typedef id (^Yielder)(void);

Yielder counter(int count) {
  __block int ii = 0;
  const __block int count0 = count;
  return [[^{
    if (ii < count) {
      int jj = ii++;
      return [NSNumber numberWithInt:jj];
    }
    return (NSNumber *)nil;
  } copy] autorelease];
}

// Would normally just use [NSFileManager enumeratorAtPath]
Yielder directory(NSString *path) {
  NSMutableArray *paths = [[NSMutableArray alloc] init];
  [paths addObject:path];
  return [[^{  
    while([paths count] > 0) {
      // Grab the last item from the list
      NSString *lastPath = [[[paths lastObject] retain] autorelease];
      [paths removeLastObject];

      // If this is a directory, appends its contents to the list
      BOOL isDirectory;
      if (![[NSFileManager defaultManager] fileExistsAtPath:lastPath isDirectory:&isDirectory])
        continue;
      if (isDirectory) {
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:lastPath error:NULL];
        if (contents == nil) continue;
        for(NSString *file in contents)
          [paths addObject:[path stringByAppendingPathComponent:file]];
      }
      
      return lastPath;
    }
    return (NSString *)nil;    
  } copy] autorelease];
}

int main (int argc, const char * argv[]) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  // Demo 1 - iterate numbers
  int count = 20;
  Yielder iter = [counter(count) retain];
  for (NSNumber *ii = iter();
       ii != nil;
       ii = iter()) {
    NSLog(@"%@", ii);
    [pool release];
    pool = [[NSAutoreleasePool alloc] init];
  }
  [iter release];
  
  // Demo 2 - iterate through a directory
  iter = [directory(@"/Users/jcho/Movies") retain];
  for (NSString *ii = iter();
       ii != nil;
       ii = iter()) {
    NSLog(@"%@", ii);
    [pool release];
    pool = [[NSAutoreleasePool alloc] init];
  }  
  [iter release];
  
  [pool release];
}
