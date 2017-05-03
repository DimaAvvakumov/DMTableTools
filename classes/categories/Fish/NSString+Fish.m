//
//  NSString+Fish.m
//  testDatabase
//
//  Created by Dmitry Avvakumov on 14.10.16.
//  Copyright © 2016 Dmitry Avvakumov. All rights reserved.
//

#import "NSString+Fish.h"

@implementation NSString (Fish)

+ (NSString *)generateRandomFishWithLength:(NSUInteger)length {
    NSString *dictString = @"Уравнение времени мгновенно Часовой угол а там действительно могли быть видны звезды о чем свидетельствует Фукидид жизненно меняет экваториальный перигелий Движение несмотря на внешние воздействия пространственно ищет случайный космический мусор Зенит однородно меняет далекий параметр Весеннее равноденствие ищет непреложный Тукан У планет-гигантов нет твёрдой поверхности таким образом Юпитер жизненно представляет собой болид  и в этом вопросе достигнута такая точность расчетов что начиная с того дня как мы видим указанного Эннием и записанного в было вычислено время предшествовавших затмений солнца начиная с того которое в квинктильские ноны произошло в царствование Ромула";
    NSArray *rawWords = [dictString componentsSeparatedByString:@" "];
    NSMutableArray *words = [NSMutableArray arrayWithCapacity:[rawWords count]];
    for (NSString *candidate in rawWords) {
        if (candidate.length > 3) {
            [words addObject:candidate];
        }
    }
    
    NSInteger newLength = 0;
    NSUInteger dictCount = [words count];
    NSString *newFrase = @"";
    while (newLength < length) {
        NSUInteger index = arc4random_uniform((uint32_t) dictCount);
        NSString *w = [words objectAtIndex:index];
        
        newLength += w.length + 1;
        if (newLength > length) break;
        
        newFrase = [[newFrase stringByAppendingString:w] stringByAppendingString:@" "];
    }
    
    return newFrase;
}

@end
