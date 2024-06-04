--Empty, Infinite, and Infinite Light
local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	aux.AddSkillProcedure(c,3,false,s.flipcon2,s.flipop2)
end

function s.filterTimelords(c)
	return c:IsSetCard(0x4a) or c:IsCode(27107590)
end

function s.monster(c)
	return c:IsMonster()
end


function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then

		local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
		local timelords = g:Filter(s.filterTimelords,nil)
		local anotherMonster = g:FilterCount(s.monster,timelords)
		local con = g:IsExists(Card.IsCode,1,nil,36894320) and g:IsExists(Card.IsCode,1,nil,72883039) and #timelords > anotherMonster
		if not con then
			Duel.RegisterFlagEffect(tp,id,0,0,0)
			Duel.RegisterFlagEffect(tp,id+1,0,0,0)
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_LEAVE_FIELD)
		e1:SetCondition(s.spcon)
		e1:SetOperation(s.levreg)
		Duel.RegisterEffect(e1,tp)
	end
	e:SetLabel(1)
end

function s.cfilter(c,tp)
	return c:IsCode(9409625,36894320,72883039) and c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end

function s.levreg(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(1)
	Duel.RegisterFlagEffect(tp,id+2,0,0,0)
end

function s.sendToGrave(c)
	return c:IsAbleToGraveAsCost()
end

function s.sephylon(c)
	return c:IsCode(8967776) and not c:IsPublic()
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	if Duel.GetFlagEffect(tp,id)>0 and Duel.GetFlagEffect(tp,id+1)>0 then return end
	--Boolean checks for the activation condition: b1, b2
	local b1=Duel.GetFlagEffect(tp,id)==0
		and Duel.IsExistingMatchingCard(s.sendToGrave,tp,LOCATION_HAND,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0

	local b2=Duel.GetFlagEffect(tp,id+1)==0 and Duel.IsExistingMatchingCard(s.sephylon,tp,LOCATION_HAND,0,1,nil) and Duel.GetFlagEffect(tp,id+2)~=0

	

	return aux.CanActivateSkill(tp) and (b1 or b2)
end

function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:
	local b1=Duel.GetFlagEffect(tp, id)==0
		and Duel.IsExistingMatchingCard(s.sendToGrave,tp,LOCATION_HAND,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0

	local b2=Duel.GetFlagEffect(tp,id+1)==0 and Duel.IsExistingMatchingCard(s.sephylon,tp,LOCATION_HAND,0,1,nil) and Duel.GetFlagEffect(tp,id+2)~=0

	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								   {b2,aux.Stringid(id,1)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end

--op=0 set 1 "Empty Machine" from outside the duel to your Spell/Trap Zone.
function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.SelectMatchingCard(tp,s.sendToGrave,tp,LOCATION_HAND,0,1,1,false,nil)
	if Duel.SendtoGrave(tg,REASON_EFFECT) then
		local cearth=Duel.CreateToken(tp,9409625)
		if Duel.SSet(tp,cearth)>0 then
			--Can be activated the turn it was Set
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			cearth:RegisterEffect(e1)

		end
	end
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

local timelords={33015627,6616912,7733560,28929131,34137269,60222213,65314286,74530899,91712985,92435533}

function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,s.sephylon,tp,LOCATION_HAND,0,1, 1,nil):GetFirst()
	if tc then
		for i=1,#timelords do
			local g=Duel.CreateToken(tp,timelords[i])
			 Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
	Duel.RegisterFlagEffect(tp,id+1,0,0,0)
end
