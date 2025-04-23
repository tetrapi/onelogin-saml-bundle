<?php

// SPDX-License-Identifier: BSD-3-Clause

declare(strict_types=1);

namespace Nbgrp\OneloginSamlBundle\Idp;

use Symfony\Component\HttpFoundation\Request;

/**
 * Represents the interface of the service that resolves the request IdP.
 */
interface IdpResolverInterface
{
    /**
     * Returns IdP name for a specified request.
     */
    public function resolve(Request $request): ?string;
}
