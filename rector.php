<?php

declare(strict_types=1);

use Rector\Config\RectorConfig;
use Rector\Exception\Configuration\InvalidConfigurationException;
use Rector\Symfony\Set\SymfonySetList;

try {
    return RectorConfig::configure()
        ->withPaths([
            __DIR__ . '/src',
            __DIR__ . '/tests',
        ])
        // uncomment to reach your current PHP version
        ->withPhpSets(php84: true)
        ->withSets(
            [
                SymfonySetList::SYMFONY_64,
                SymfonySetList::ANNOTATIONS_TO_ATTRIBUTES,
                SymfonySetList::SYMFONY_CODE_QUALITY,
                SymfonySetList::SYMFONY_CONSTRUCTOR_INJECTION
            ]
        )
        ->withPreparedSets(deadCode: true, codeQuality: true)
        ->withTypeCoverageLevel(0);
} catch (InvalidConfigurationException $e) {
    exit($e->getMessage());
}
