<?php

// SPDX-License-Identifier: BSD-3-Clause

declare(strict_types=1);

namespace Nbgrp\OneloginSamlBundle\Security\User;

use Symfony\Component\Security\Core\User\UserInterface;

/**
 * Represents the interface of user factory that used for JIT user provisioning.
 *
 * Allows creating a user when it is not found by the user provider during authorization.
 */
interface SamlUserFactoryInterface
{
    public function createUser(string $identifier, array $attributes): UserInterface;
}
